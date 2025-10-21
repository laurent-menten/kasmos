#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket, threading, queue, time, sys, tkinter as tk
from tkinter import ttk, messagebox

# Defaults
SER0_HOST, SER0_PORT = "127.0.0.1", 6667
DBG0_HOST, DBG0_PORT = "127.0.0.1", 6668
RECONNECT_DELAY_SEC, RECV_BUF = 1.0, 4096

# ---------------- Networking ----------------
class SocketReader(threading.Thread):
    daemon = True
    def __init__(self, name, host, port, out_queue, status_cb=None):
        super().__init__(name=name)
        self.host, self.port, self.out_queue = host, port, out_queue
        self.status_cb = status_cb or (lambda *_: None)
        self._stop = threading.Event()
        self.sock, self.connected = None, False

    def stop(self):
        self._stop.set()
        try:
            if self.sock: self.sock.shutdown(socket.SHUT_RDWR)
        except Exception: pass
        try:
            if self.sock: self.sock.close()
        except Exception: pass

    def run(self):
        while not self._stop.is_set():
            if not self.connected:
                try:
                    self.status_cb(f"[{self.name}] connecting to {self.host}:{self.port}…")
                    s = socket.create_connection((self.host, self.port), timeout=5.0)
                    s.settimeout(0.5)
                    self.sock, self.connected = s, True
                    self.status_cb(f"[{self.name}] connected.")
                except Exception as e:
                    self.status_cb(f"[{self.name}] waiting… ({e})")
                    time.sleep(RECONNECT_DELAY_SEC)
                    continue
            try:
                data = self.sock.recv(RECV_BUF)
                if not data:
                    self.status_cb(f"[{self.name}] connection closed by peer.")
                    self._close_socket(); continue
                self.out_queue.put(data)
            except socket.timeout:
                continue
            except Exception as e:
                self.status_cb(f"[{self.name}] socket error: {e}")
                self._close_socket()

    def _close_socket(self):
        self.connected = False
        try:
            if self.sock: self.sock.close()
        except Exception: pass
        self.sock = None

class SocketWriter:
    def __init__(self, reader: SocketReader):
        self.reader, self._lock = reader, threading.Lock()
    def send(self, data: bytes):
        with self._lock:
            s = self.reader.sock
            if not (s and self.reader.connected): raise RuntimeError("Socket not connected.")
            s.sendall(data)

# ---------------- UI ----------------
class ScrolledText(tk.Text):
    def __init__(self, master, **kwargs):
        frame = ttk.Frame(master)
        self.vbar = ttk.Scrollbar(frame, orient="vertical")
        super().__init__(frame, wrap="word", yscrollcommand=self.vbar.set, **kwargs)
        self.vbar.config(command=self.yview)
        self.vbar.pack(side="right", fill="y")
        super().pack(side="left", fill="both", expand=True)
        self._outer = frame
    def pack(self, *a, **k): self._outer.pack(*a, **k)

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("QEMU dbg0↑ / ser0↓"); self.geometry("1100x700")
        self.q_dbg, self.q_ser = queue.Queue(), queue.Queue()
        self._dbg_buf, self._ser_buf = b"", b""

        paned = ttk.Panedwindow(self, orient="vertical"); paned.pack(fill="both", expand=True)

        # Top: dbg0 (read-only, tagged)
        top = ttk.Frame(paned)
        ttk.Label(top, text="dbg0 (0xE9) – output").pack(anchor="w")
        self.txt_dbg = ScrolledText(top, height=12, state="disabled"); self.txt_dbg.pack(fill="both", expand=True, pady=(2,8))
        self._config_tags(self.txt_dbg)
        ttk.Button(top, text="Clear dbg0", command=self.clear_dbg).pack(anchor="e")
        paned.add(top, weight=1)

        # Bottom: ser0 (interactive, tagged)
        bottom = ttk.Frame(paned)
        ttk.Label(bottom, text="ser0 (COM1) – I/O").pack(anchor="w")
        self.txt_ser = ScrolledText(bottom, height=12); self.txt_ser.pack(fill="both", expand=True, pady=(2,8))
        self._config_tags(self.txt_ser)

        send_frame = ttk.Frame(bottom)
        self.entry = ttk.Entry(send_frame); self.entry.pack(side="left", fill="x", expand=True)
        self.entry.bind("<Return>", self.on_send)
        self.var_crlf = tk.BooleanVar(value=True)
        ttk.Checkbutton(send_frame, text="CRLF (\\r\\n)", variable=self.var_crlf).pack(side="left", padx=6)
        ttk.Button(send_frame, text="Send", command=self.on_send).pack(side="left", padx=4)
        ttk.Button(send_frame, text="Clear ser0", command=self.clear_ser).pack(side="left", padx=4)
        send_frame.pack(fill="x"); paned.add(bottom, weight=1)

        # Status bar (bottom)
        self.status_var = tk.StringVar(value="Ready."); ttk.Label(self, textvariable=self.status_var, anchor="w").pack(side="bottom", fill="x")

        # Networking
        self.reader_dbg = SocketReader("dbg0", DBG0_HOST, DBG0_PORT, self.q_dbg, status_cb=self.set_status)
        self.reader_ser = SocketReader("ser0", SER0_HOST, SER0_PORT, self.q_ser, status_cb=self.set_status)
        self.writer_ser = SocketWriter(self.reader_ser)
        self.reader_dbg.start(); self.reader_ser.start()

        self.after(20, self._drain_queues)
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    # --- helpers ---
    def _config_tags(self, widget: tk.Text):
        widget.tag_configure("info",  foreground="#0a6b2c", background="#e7f5e9")
        widget.tag_configure("warn",  foreground="#8a6a00", background="#fff4ce")
        widget.tag_configure("error", foreground="#b71c1c", background="#ffe5e5")
        widget.tag_configure("plain", foreground="#222222")

    def set_status(self, msg: str): self.after(0, lambda: self.status_var.set(msg))

    def _decode(self, b: bytes) -> str:
        try: return b.decode("utf-8", errors="replace")
        except Exception: return b.decode("latin-1", errors="replace")

    def _norm_newlines(self, b: bytes) -> bytes:
        # 1) CRLF -> LF
        b = b.replace(b"\r\n", b"\n")
        # 2) Supprimer tout CR isolé (évite les lignes vides ou les carrés)
        b = b.replace(b"\r", b"")
        return b

    def _classify_tag(self, s: str) -> str:
        low = s.lstrip().lower()  # allow leading spaces
        if   low.startswith("[error]"): return "error"
        elif low.startswith("[warn]"):  return "warn"
        elif low.startswith("[info]"):  return "info"
        else:                           return "plain"

    def _insert_tagged_line(self, widget: tk.Text, s: str, readonly=False):
        tag = self._classify_tag(s)
        if readonly: widget.config(state="normal")
        widget.insert("end", s.rstrip("\n") + "\n", (tag,))
        widget.see("end")
        if readonly: widget.config(state="disabled")

    def _drain_queues(self):
        # dbg0: normalize + reassemble lines + tag
        while True:
            try: chunk = self.q_dbg.get_nowait()
            except queue.Empty: break
            self._dbg_buf += self._norm_newlines(chunk)
            parts = self._dbg_buf.split(b"\n"); self._dbg_buf = parts[-1]
            for p in parts[:-1]:
                self._insert_tagged_line(self.txt_dbg, self._decode(p), readonly=True)

        # ser0: normalize + reassemble lines + tag (no readonly)
        while True:
            try: chunk = self.q_ser.get_nowait()
            except queue.Empty: break
            self._ser_buf += self._norm_newlines(chunk)
            parts = self._ser_buf.split(b"\n"); self._ser_buf = parts[-1]
            for p in parts[:-1]:
                self._insert_tagged_line(self.txt_ser, self._decode(p), readonly=False)

        self.after(20, self._drain_queues)

    def on_send(self, event=None):
        text = self.entry.get()
        if not text: return
        payload = text
        if self.var_crlf.get():
            if not payload.endswith("\n"): payload += "\n"
            payload = payload.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")
        else:
            if not payload.endswith("\n"): payload += "\n"
        try:
            self.writer_ser.send(payload.encode("utf-8", errors="replace"))
        except Exception as e:
            messagebox.showerror("Send failed", f"Cannot send to ser0: {e}")
        finally:
            self.entry.delete(0, "end")

    def clear_dbg(self):
        self.txt_dbg.config(state="normal"); self.txt_dbg.delete("1.0", "end"); self.txt_dbg.config(state="disabled")
    def clear_ser(self): self.txt_ser.delete("1.0", "end")

    def on_close(self):
        try: self.reader_dbg.stop(); self.reader_ser.stop()
        except Exception: pass
        self.after(100, self.destroy)

if __name__ == "__main__":
    if len(sys.argv) == 5:
        SER0_HOST, SER0_PORT = sys.argv[1], int(sys.argv[2])
        DBG0_HOST, DBG0_PORT = sys.argv[3], int(sys.argv[4])
    elif len(sys.argv) not in (1,):
        print(f"Usage: {sys.argv[0]} [SER_HOST SER_PORT DBG_HOST DBG_PORT]"); sys.exit(2)
    App().mainloop()

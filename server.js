import http from "http";
import net from "net";
import { WebSocketServer } from "ws";

const PORT = parseInt(process.env.PORT || "8080", 10);

// Simple HTTP response for health checks / browser test
const server = http.createServer((req, res) => {
  res.writeHead(200, { "content-type": "text/plain" });
  res.end("OK\n");
});

// WebSocket -> TCP bridge to local SSH
const wss = new WebSocketServer({ server });

wss.on("connection", (ws) => {
  const tcp = net.connect({ host: "127.0.0.1", port: 22 });

  // WS -> SSH
  ws.on("message", (data) => {
    if (tcp.writable) tcp.write(Buffer.from(data));
  });

  // SSH -> WS
  tcp.on("data", (chunk) => {
    if (ws.readyState === ws.OPEN) ws.send(chunk);
  });

  const closeBoth = () => {
    try { ws.close(); } catch {}
    try { tcp.destroy(); } catch {}
  };

  ws.on("close", closeBoth);
  ws.on("error", closeBoth);
  tcp.on("close", closeBoth);
  tcp.on("error", closeBoth);
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`HTTP/WS listening on 0.0.0.0:${PORT}`);
});

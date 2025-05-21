import asyncio
import websockets
import json
import random
import time

clients = set()

async def send_to_clients(alert_data):
    message = json.dumps(alert_data)
    if not clients:
        print("⚠️ No connected clients to send to.")
        return

    for client in list(clients):
        print(f"🔍 Checking client {client.remote_address}...")

        # Try to check if client is open in multiple ways
        is_open = False
        if hasattr(client, 'open'):
            is_open = client.open
        elif hasattr(client, 'closed'):
            # could be a method or attribute, handle both:
            attr = client.closed
            if callable(attr):
                is_open = not attr()
            else:
                is_open = not attr
        else:
            # fallback: try sending and catch errors
            is_open = True

        print(f"Is client open? {is_open}")

        if is_open:
            try:
                await client.send(message)
                print(f"✅ Sent to {client.remote_address}")
            except Exception as e:
                print(f"⚠️ Error sending to {client.remote_address}: {e}")
                clients.remove(client)
        else:
            print(f"⚠️ Client {client.remote_address} is closed.")
            clients.remove(client)



async def handler(websocket):
    print(f"🧩 Client connected: {websocket.remote_address}")
    clients.add(websocket)
    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                if data.get("ping"):
                    await websocket.send(json.dumps({"status": "connected"}))
                    print(f"🔁 Ping received from {websocket.remote_address}, sent confirmation.")
            except json.JSONDecodeError:
                pass
    finally:
        print(f"❌ Client disconnected: {websocket.remote_address}")
        clients.remove(websocket)


# Dummy alert generator
async def start_server():
    print("🚀 Starting WebSocket server...")
    async with websockets.serve(handler, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(start_server())

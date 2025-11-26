# SkribblClone ✍️: Real-Time Drawing Game

A multiplayer mobile game built to recreate the Skribbl.io experience. Players join private rooms to draw, guess the secret word in real-time chat, and compete for the high score.

## 🌟 Features

* **Multiplayer Lobbies:** Create or join private rooms with custom settings (rounds, size).
* **Real-Time Drawing:** Low-latency synchronization of brush strokes across all players.
* **Custom Tools:** Control **color**, **stroke width**, and **clear the canvas** (only the drawer).
* **Turn Management:** Automatic rotation, countdown timer (60s), and word assignment (with masking/hints).
* **Game Chat:** Real-time chat for guessing the word. Correct guesses award instant points.
* **Score & Leaderboard:** Dynamic sidebar scoreboard and a final screen to crown the winner.
* **Built on:** Flutter (Client) and Node.js/Socket.IO (Server).

---

## 🛠️ Technologies

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Frontend** | **Flutter / Dart** | Mobile client UI and state management. |
| **Backend** | **Node.js / Express** | Handling game logic and API endpoints. |
| **Real-Time** | **Socket.IO** | Core for low-latency drawing and chat synchronization. |
| **Database** | **MongoDB (Mongoose)** | Storing room and player state data. |

---

## ▶️ Getting Started

Follow these steps to run the game locally.

### Prerequisites

* **Node.js** and **npm**
* **Flutter SDK**
* **MongoDB** instance (running)

### Installation

1.  **Clone the Repo:**
    ```bash
    git clone [https://github.com/CristianEk/skribbl_clone.git](https://github.com/CristianEk/skribbl_clone.git)
    cd skribbl_clone
    ```
2.  **Start the Server:**
    ```bash
    cd server
    npm install
    # Ensure your MongoDB connection is set in index.js
    npm start
    ```
3.  **Run the Flutter Client:**
    ```bash
    cd ..
    flutter pub get
    # IMPORTANT: Update the connection IP in lib/paint_screen.dart to your local IPv4.
    flutter run
    ```

---

## ⚙️ Usage & Network Notes

* **Local IP:** The Flutter client must use your current Wi-Fi IPv4 address (e.g., `http://10.64.133.54:3000`) to connect.
* **Firewall:** Ensure your operating system's firewall has an exception for TCP port **`3000`** to allow connections from other devices.

---

Cristian Ek

Project source by Rivaan Ranawat
https://www.youtube.com/watch?v=afCVHB2xm-g

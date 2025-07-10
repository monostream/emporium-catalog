# Wastebin

Share code and text instantly with this fast, secure, and privacy-focused pastebin service. Perfect for developers, writers, and anyone who needs to share text snippets quickly and safely.

## Features

- **🚀 Lightning Fast**: Built with Rust for maximum performance and minimal resource usage
- **🔒 Secure by Design**: Optional ChaCha20Poly1305 encryption for sensitive pastes
- **🎨 Beautiful Code**: Syntax highlighting for 20+ programming languages with 8 stunning themes
- **📱 Mobile Friendly**: QR codes for easy mobile access to your pastes
- **💾 Smart Storage**: Automatic zstd compression saves space while maintaining speed
- **🌈 Customizable**: Choose from 8 beautiful themes (ayu, base16ocean, catppuccin, coldark, gruvbox, monokai, onehalf, solarized)
- **🔐 Privacy First**: Self-hosted solution - your data stays on your infrastructure
- **⚡ Lightweight**: Single binary with low memory footprint
- **🗃️ Persistent**: SQLite database ensures your pastes are safely stored

## Perfect For

- **Developers**: Share code snippets with beautiful syntax highlighting
- **Writers**: Quick text sharing with markdown support
- **Teams**: Secure internal paste sharing
- **Students**: Share assignments and notes safely
- **Anyone**: Who values privacy and speed in text sharing

## Usage

After installation, simply visit your Wastebin URL and start pasting! Features include:

- **Keyboard Shortcuts**: Press `Ctrl+S` to create a new paste
- **Paste Options**: Set expiration time, burn after reading, or encrypt with password
- **Mobile Access**: View QR codes to easily access pastes on mobile devices
- **Raw Access**: Direct access to paste content via `/raw/:id` endpoint

For more information, visit [Wastebin on GitHub](https://github.com/matze/wastebin). 
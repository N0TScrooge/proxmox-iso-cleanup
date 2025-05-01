# Proxmox VE ISO Cleanup

A Bash script for finding and deleting ISO images across all storages in Proxmox VE.

## Features

- 🔍 **Automatic discovery**: Scans all storages in your Proxmox VE environment
- 📋 **Comprehensive listing**: Displays all ISO images with their storage location and size
- 🗑️ **Interactive deletion**: Choose between confirming each deletion or batch removal
- 🔄 **User-friendly interface**: Color-coded output for better readability
- 🛡️ **Confirmation prompts**: Prevents accidental deletion of important files

## Usage

1. Download the script to your Proxmox VE host:
   ```bash
   wget https://raw.githubusercontent.com/N0TScrooge/proxmox-iso-cleanup/main/proxmox-iso-cleanup.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x proxmox-iso-cleanup.sh
   ```

3. Run the script:
   ```bash
   ./proxmox-iso-cleanup.sh
   ```

## Workflow

1. The script scans all storage locations in your Proxmox VE environment
2. It displays a list of all found ISO images with details
3. You'll be asked if you want to delete the found ISO images
4. If yes, you can choose between two deletion modes:
   - Delete each ISO separately (with confirmation for each)
   - Delete all found ISOs without additional prompts

## Requirements

- Proxmox VE 6.0 or higher
- Bash shell
- Administrative privileges (root access or sudo)

## Screenshots

![Screenshot of ISO listing](https://example.com/screenshot1.png)
![Screenshot of deletion process](https://example.com/screenshot2.png)

## Caution

This script directly interacts with your Proxmox VE storage. Always make sure you understand what you're deleting. Consider backing up important ISO images before running this cleanup script.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](LICENSE) file for details.

The use of this code and derivative works for training, testing, or validating artificial intelligence models is strictly prohibited without the prior written consent of the author.

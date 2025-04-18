# Moonlight DevTools

### Scripts  
#### GitHub SSH  
* MacOS/Linux setup  

    ```dart
    # Dar permissão de execução
    chmod +x github_ssh_macos.sh  # ou github_ssh_linux.sh

    # Executar com o e-mail como parâmetro
    ./github_ssh_macos.sh seu-email@moonlightmobile.dev
    ```

* Windows setup  
    - Execute PowerShell as admin  
        ```powershell
            .\github_ssh_windows.ps1 "seu-email@moonlightmobile.dev"
        ```
    * In case of error, try the command below:
        ```powershell
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        ```
    * Restart PowerShell and run
        ```powershell
            .\github_ssh_windows.ps1 "seu-email@moonlightmobile.dev"
        ```
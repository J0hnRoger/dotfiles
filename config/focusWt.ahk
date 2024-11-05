#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Capslock::Esc

^+G:: ; Ctrl + Shift + G
{
    If WinExist("Stoic PowerShell")
    {
        WinActivate
    }
    else
    {
        Run wt -p "Stoic PowerShell"
    }

    WinWaitActive, Stoic PowerShell, , 1 ; Attendre que la fenêtre soit active avec un délai de 2 secondes
    if ErrorLevel ; Si la fenêtre n'est pas active après 2 secondes
    {
        return ; Quitte le script
    }

    Sleep, 200 ; Attendre un peu pour laisser le temps à la fenêtre de répondre
    Send, clear{Enter} ; 
    Send, t day show{Enter} ; Envoie la commande 't day show' suivie d'Enter
    return
}


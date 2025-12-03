;Activer la touche TAB et neutraliser les caracteres speciaux

EnableExplicit

Enumeration Form
  #Mainform
  #StatusBar
EndEnumeration

Enumeration Menu
  #MainMenu
  #Quit
EndEnumeration

Enumeration Gadget  
  #Editor
EndEnumeration

;-Déclaration variable et procédures 
Global WindowStyle.i=#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_ScreenCentered|#PB_Window_SizeGadget

;-Plan de l'application
Declare Start()

Declare MainFormShow() 
Declare MainFormResize()
Declare MainFormClose()

Declare ScintillaCallBack(Gadget, *scinotify.SCNotification)

Start()

;Début
Procedure Start()
  MainFormShow()
  
  BindEvent(#PB_Event_SizeWindow, @MainFormResize(), #MainForm)
  BindEvent(#PB_Event_CloseWindow, @MainFormClose(), #MainForm)
  
  BindMenuEvent(#MainMenu, #Quit, @MainFormClose())
  
  Repeat : WaitWindowEvent(10) : ForEver
EndProcedure

;-
;- U.T. Fenetres, Menu, Gadgets
Procedure MainFormShow()  
  OpenWindow(#MainForm,  0,  0, 1024, 768, "Pure Basic Editor : Préliminaire", WindowStyle)
  
  ;Barre de status
  If CreateStatusBar(#StatusBar,WindowID(#Mainform))
    AddStatusBarField(150)
    AddStatusBarField(450)
  EndIf 
  
  ;Evite le scintillement du Scintilla gadget lors du redimentionnement de la fenetre 
  SmartWindowRefresh(#Mainform, #True)
  
  ;Menu de l'application
  CreateMenu(#mainmenu,WindowID(#MainForm))
  MenuTitle("Fichier")
  MenuItem(#Quit,"Quitter")
  
  ;If InitScintilla()
    ;@ScintillaCallBack() est une procédure callback qui recevra  les évènements émis par ScintillaGadget 
    ScintillaGadget(#Editor, 10, 40, 1004, 668, @ScintillaCallBack())   
    SetActiveGadget(#Editor)
  ;EndIf
  
  ;-Préliminaires 
  
  ;-Neutraliser la touche TAB
  RemoveKeyboardShortcut(#Mainform, #PB_Shortcut_Tab)
  
  ;-Neutraliser les caractéres spéciaux
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_B, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_G, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_E, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_R, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_O, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_P, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_Q, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_S, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_F, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_H, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_K, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_W, 0)  
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_N, 0)
EndProcedure

;Redimensionnement de la fenetre principale
Procedure MainFormResize()
  ResizeGadget(#Editor, #PB_Ignore, #PB_Ignore, WindowWidth(#MainForm)-20, WindowHeight(#Mainform)-100)
EndProcedure

Procedure MainFormClose()
  End
EndProcedure

;-
;- U.T. Scintilla
Procedure ScintillaCallBack(Gadget, *scinotify.SCNotification)
  ;Pour le moment rien mais ça va venir :)
EndProcedure

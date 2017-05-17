Victory_DefectionStateMachine::
    ld a, [W_Battle_4thOrderSubState]
    ld hl, .stateTable
    call System_IndexWordList
    jp [hl]
    
.stateTable
    dw Victory_SubStateDrawDefectionScreen, Victory_SubStateFadeInDefectionScreen
    dw Victory_SubStateDefectionScreenText, Victory_SubStateDefectionScreenFinish
    dw Victory_SubStateFadeOutDefectionScreen, Victory_SubStateExitDefectionScreen
    
Victory_SubStateDrawDefectionScreen::
    ld bc, $16
    call Banked_LoadMaliasGraphics
    
    ld bc, $9
    call Banked_LoadMaliasGraphics
    
    ld bc, $E
    call Banked_CGBLoadBackgroundPalette
    
    ld a, $28
    call PauseMenu_CGBStageFlavourPalette
    
    ld bc, 0
    ld e, $70
    lc a, 0
    call Banked_RLEDecompressTMAP0
    
    ld bc, 0
    ld e, $70
    lc a, 0
    call Banked_RLEDecompressAttribsTMAP0
    
    ld bc, $605
    ld e, $91
    lc a, 0
    call Banked_RLEDecompressTMAP0
    
    ld bc, $605
    ld e, $8B
    lc a, 0
    call Banked_RLEDecompressAttribsTMAP0
    
    ld a, [W_Victory_ContactsPresent]
    cp 1
    jr z, .migrateContactId
    
.deindexLostContact
    call Victory_DeleteContact
    jr .processContactLoss
    
.migrateContactId
    ld a, [W_PauseMenu_DeletedContact]
    ld [W_Victory_DefectedContact], a
    
.processContactLoss
    call SaveClock_EnterSRAM2
    
    ld hl, $A000 + M_SaveClock_DenjuuSpecies
    ld a, [W_Victory_DefectedContact]
    call Battle_IndexStatisticsArray
    
    push hl
    
    ld a, [hli]
    ld [W_Victory_DefectedContactSpecies], a
    ld a, [hl]
    ld [W_Victory_DefectedContactLevel], a
    
    pop hl
    
    ld a, M_SaveClock_DenjuuStatSize
    
.eraseLoop
    ld [hl], 0
    inc hl
    dec a
    jr nz, .eraseLoop
    
    call SaveClock_ExitSRAM
    
    ld a, [W_Victory_ContactsPresent]
    dec a
    ld [W_Victory_ContactsPresent], a
    
    ld a, [W_Victory_DefectedContact]
    ld c, a
    call $6A4
    
    ld a, 0
    ld [W_PauseMenu_CurrentContact], a
    
    ld a, [W_Victory_DefectedContactSpecies]
    ld de, $9100
    call Status_LoadEvolutionIndicatorBySpecies
    
    ld a, [W_Victory_DefectedContactSpecies]
    push af
    ld c, 0
    ld de, $8800
    call Banked_Battle_LoadDenjuuPortrait
    
    pop af
    call Battle_LoadDenjuuPaletteOpponent
    
    ld hl, $9580
    ld a, 8
    call MainScript_DrawEmptySpaces
    
    ld hl, $9580
    ld a, [W_Victory_DefectedContact]
    call Status_DrawDenjuuNickname
    
    ld c, M_Battle_MessageDenjuuDefected
    call Battle_QueueMessage
    
    ld a, [W_Victory_DefectedContactLevel]
    ld hl, $984A
    ld c, 1
    call Encounter_DrawTileDigits
    
    ld a, $2E
    call Sound_IndexMusicSetBySong
    ld [byte_FFA0], a
    
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    
    ld a, [W_Battle_4thOrderSubState]
    inc a
    ld [W_Battle_4thOrderSubState], a
    ret
    
Victory_SubStateFadeInDefectionScreen::
    ld a, 0
    call Banked_LCDC_PaletteFade
    or a
    ret z
    
    ld a, [W_Battle_4thOrderSubState]
    inc a
    ld [W_Battle_4thOrderSubState], a
    ret
    
Victory_SubStateDefectionScreenText::
    call Banked_MainScriptMachine
    ld a, [W_MainScript_State]
    cp M_MainScript_StateTerminated
    ret nz
    
    ld a, [W_Battle_4thOrderSubState]
    inc a
    ld [W_Battle_4thOrderSubState], a
    ret
    
Victory_SubStateDefectionScreenFinish::
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    
    ld a, $10
    ld [$CF96], a
    
    ld a, [W_Battle_4thOrderSubState]
    inc a
    ld [W_Battle_4thOrderSubState], a
    ret
    
Victory_SubStateFadeOutDefectionScreen::
    ld a, 1
    call Banked_LCDC_PaletteFade
    or a
    ret z
    
    ld a, [W_Battle_4thOrderSubState]
    inc a
    ld [W_Battle_4thOrderSubState], a
    ret
    
Victory_SubStateExitDefectionScreen::
    xor a
    ld [W_Battle_4thOrderSubState], a
    ld a, 9
    ld [W_Battle_SubSubState], a
    ret
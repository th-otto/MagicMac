/*
*
* Diese Datei beschreibt den Aufbau der Übergabestruktur,
* mit der sich VT52.PRG ins System einhängt.
* VT52 muß die Adresse 0x98c auf NULL lassen, damit es
* keinen Konflikt mit der alten Version gibt. VT52 hängt seine
* Struktur in Adresse 0x990 ein.
*
*    <sout_cooked> gibt eine Zeichenkette aus, unter
*  Berücksichtigung von ^C.
*
*  <cin_cooked> liest ein Zeichen von der Tastatur ein, unter
*  Berücksichtigung von ^C.
*
*  <inherit> vererbt ein Terminalfenster von einem Task an
*  einen anderen (i.a. mehrere Threads und ein Prozeß).
*
*  <uninherit> meldet den Task für sein Terminalfenster wieder
*  ab, wenn z.B. der Task bzw. der Signalhandler terminiert.
*
*  <bg> schickt einen Task in den Hintergrund, d.h. er bekommt
*  keine Tastatureingaben mehr.
*
*  <fg> legt den Task wieder in den Vordergrund.
*
*/

     OFFSET

vt_version:         DS.L 1    /* Versionsnummer der Struktur */
vt_getVDIESC:       DS.L 1    /* d0 = VDIESC-Sequenz für APPL a0 */
vt_sout_cooked:     DS.L 1
vt_cin_cooked:      DS.L 1
vt_inherit:         DS.L 1
vt_uninherit:       DS.L 1
vt_bg:              DS.L 1
vt_fg:              DS.L 1

     TEXT

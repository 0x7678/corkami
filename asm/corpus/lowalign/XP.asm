; Low Alignment PE for XP, with 96 sections.

; Ange Albertini, BSD LICENCE 2009-2011

%include '..\..\consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 4
FILEALIGN equ 4

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend

istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw 96
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 77000000h ; filesize <= SizeofImage <= 77000000h
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd 2ch ; 2ch <= SIZEOFHEADERS < SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE ; required under XP if no section
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
; 0 <= VirtualSize <= SizeOfRawData <= 077777777h (on 1st section only ?)
; 0 <= VirtualAddress == PointerToRawData <= 88888888h (on 1st section only ?)
; Flags are totally ignored
istruc IMAGE_SECTION_HEADER
times 8 db '*'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 0 
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 88888888h
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 77777777h 
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 88888888h 
times 12 db '*'
    at IMAGE_SECTION_HEADER.Characteristics,  dd 0
iend
%assign i 1
%rep 95
istruc IMAGE_SECTION_HEADER
dd ((i * 923456e7h)^ 0fabc4567h) & 0ffffffffh
dd ((i * 0a9123456h)^ 0bc4567h) & 0ffffffffh
    at IMAGE_SECTION_HEADER.VirtualSize,      dd ((i * 1234f567h) ^ 0fabc4567h) & 0ffffffffh
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd (i * 123456h)^ 0bc4567h
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd (((i * 1234f567h) ^ 0fabc4567h ) + i) & 0ffffffffh
    at IMAGE_SECTION_HEADER.PointerToRawData, dd (i * 123456h)^ 0bc4567h
dd ((i * 092384567h)^ 0fabc4567h) & 0ffffffffh
dd ((i * 086206856h)^ 0bc64a567h) & 0ffffffffh
dd ((i * 0a85b69e6h)^ 0bc45235h ) & 0ffffffffh
    at IMAGE_SECTION_HEADER.Characteristics,  dd ((i * 0d459d9e6h)^ 0bc45235h) & 0ffffffffh
iend
%assign i i+1
%endrep

EntryPoint:
    push helloworld
    call [__imp__printf]
    add esp, 1 * 4
    push 0
    call [__imp__ExitProcess]
_c

helloworld db "Low Alignment - 96 sections PE (XP)", 0ah, 0
_d

Import_Descriptor:
kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    DD hnExitProcess - IMAGEBASE
    DD 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

ImportsAddressTable:
kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable
_d

kernel32.dll  DB 'kernel32.dll', 0
msvcrt.dll  DB 'msvcrt.dll' ;, 0
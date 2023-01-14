# shared-scripts

Fix LNK Files.ps1
-------------------------------
Script to correct issues caused by Microsoft Defender removal of lnk files 01/13/2023. Source of lnk files can be created by copying 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs' folder from source computers (non-affected computers) into centralized folder using SCCM/Intune.

Script example was used with AppDeployToolkit and source deployed via SCCM.

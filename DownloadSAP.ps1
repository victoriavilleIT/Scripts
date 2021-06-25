Invoke-WebRequest 'https://faronicsdeploystorage.s3.ca-central-1.amazonaws.com/SAP/SAP+750.zip' -Outfile 'C:\Temp\SAP750.zip'
ping -n 30 127.0.0.1
Invoke-WebRequest 'https://faronicsdeploystorage.s3.ca-central-1.amazonaws.com/SAP/SAP+750+-+Patch+12.zip' -Outfile 'C:\Temp\SAP750Patch12.zip'
ping -n 30 127.0.0.1
Invoke-WebRequest 'https://faronicsdeploystorage.s3.ca-central-1.amazonaws.com/SAP/SAP+Patch+Text.zip' -Outfile 'C:\Temp\SAP750Patchtext.zip'
ping -n 30 127.0.0.1
Expand-Archive -LiteralPath C:\Temp\SAP750.zip -DestinationPath C:\Temp\SAP750
ping -n 30 127.0.0.1
Expand-Archive -LiteralPath C:\Temp\SAP750Patch.zip -DestinationPath C:\Temp\SAP750Patch
ping -n 30 127.0.0.1
Expand-Archive -LiteralPath C:\Temp\SAP750Patch12.zip -DestinationPath C:\Temp\SAP750Patch12
ping -n 30 127.0.0.1
Expand-Archive -LiteralPath C:\Temp\SAP750Patchtext.zip -DestinationPath C:\Temp\SAP750Patchtext
ping -n 30 127.0.0.1

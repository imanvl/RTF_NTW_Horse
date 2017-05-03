README

The code was received from Grzegorz Halaj on 26/5/2014.

Email:

Dear networkers,
I have finally managed to clean the Python codes for the endogenous networks model.
The source file and the input files are attached in the RTF.zip.
I tried to comment the code but I am sure it can still be quite complicated to follow.
I assume that Ib perhaps could have a critical look (given his experience in pythonic programming) and let me know what remains unclear and requires further commenting.


Briefly about the input files.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bs_trimmed.csv contains balance sheet data (the structure of the file explained in the code: lines 1094-1104 – you can already see that it is a pretty long code)
r_init.csv – interbank funding rates (each entry corresponds to a bank)
sigma_init.csv – risk of the interbank rates (including interest rate risk and default risk, as described in details in the ECB WP 1646, soon available as Quantitative Finance paper)
sigma3_init.csv – counterparty default risk
Q2_init.csv – correlation of interbank funding rates
Q3_init.csv – correlation of counterparty default risk
eI_init.csv – capital allocated to the interbank portfolio
cva_zero.csv – CVA adjustment factor (\gamma in the paper)
pgeo.csv – probability map (described in details in ECB WP 1506)

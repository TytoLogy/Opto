% process multielectrode data

optoproc('file', 'E:\Data\EphysData\000\20190913\000_20190913_0_0_5000_TONE_LEVEL.dat', ...
            'channel', 5, ...
            'PLOT_RLF')
        
        
        
 optoproc('channel', 5, ...
            'PLOT_RLF')
        
        
  optoproc('file', 'E:\Data\EphysData\1344\20190913\1344_20190913_01_01_1285_BBN.dat', 'channel', 5, ...
            'PLOT_PSTH_BY_LEVEL')
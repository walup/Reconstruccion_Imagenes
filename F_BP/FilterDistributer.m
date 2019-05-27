function filt = FilterDistributer(filter,point,normFreq)
switch(filter)
    case Filter.RAMP
        filt = 1;
    case Filter.HAMMING
        filt = 0.54-0.46*cos(2*pi*point/(2*normFreq));
    case Filter.HANNING
        filt = 0.5*(1+cos(2*pi*point/(2*normFreq)));
   
        
        
    
        
    
    
end



end
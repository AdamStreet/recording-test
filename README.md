# Record-monitoring issue of AVAudioRecorder

**Issue:**

**-[AVAudioRecorder averagePowerForChannel:] gives back way too high (out-of-interval) value.**

Apple Docs:
> Return Value
> 
> The current average power, in decibels, for the sound being recorded. A return value of 0 dB indicates full scale, or maximum power; a return value of -160 dB indicates minimum power (that is, near silence).
> 
> If the signal provided to the audio recorder exceeds ±full scale, then the return value may exceed 0 (that is, it may enter the positive range).

Failing use-case:

* Run the app, grant the required persmission
* Scretch or blow into the internal mic of the device

Result: average audio power could reach +25db instead of staying between [-160, 0].

*Assertions are added to check the average & peak values.*

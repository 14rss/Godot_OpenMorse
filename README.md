Radial Progress Plugin by Kamel Mohammad and DaveTheCoder on AssetLib

This application uses procedural audio generation, generating a sine wave, rather than using an audio file. This clears up memory, but can be a little hard on the processor if not used properly. I will further optimize this audio generator, but for now, it may crackle and pop due to the mid-range bitrate. Feel free to tinker with it as you wish.





Structure your project as such:

>Control (Control Node)
>>   Text (Control Node)
>>>        MorseTextLabel (RichTextLabel Node)
>>>        LetterLabel (RichTextLabel Node)
>>    Controls (Control Node)
>>>        Clicker (Button Node)
>>>        ClickTimer (Timer Node)
>>>        OffTimer (Timer Node)
>>>        Feedback (AudioStreamGenerator)
>>>        Clear (Button Node)
>>>        ClickTimeProgress (RadialProgress Node)
>>>        OffTimeProgress (RadialProgress Node)

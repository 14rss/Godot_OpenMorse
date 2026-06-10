Radial Progress Plugin by Kamel Mohammad and DaveTheCoder on AssetLib

Structure your project as such:

Control (Control Node)
    Text (Control Node)
        MorseTextLabel (RichTextLabel Node)
        LetterLabel (RichTextLabel Node)
    Controls (Control Node)
        Clicker (Button Node)
        ClickTimer (Timer Node)
        OffTimer (Timer Node)
        Feedback (AudioStreamGenerator)
        Clear (Button Node)
        ClickTimeProgress (RadialProgress Node)
        OffTimeProgress (RadialProgress Node)

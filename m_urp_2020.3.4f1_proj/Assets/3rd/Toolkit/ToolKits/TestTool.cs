using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestTool : BaseToolKit
{
    public override GUIContent Content()
    {
        return new GUIContent(this.ToString());
    }

    public override void OnGUI()
    {
        
    }
}

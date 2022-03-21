using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Jefford/TipAsset", fileName = "new TipAsset")]
public class ScriptableObjectTutorial : ScriptableObject
{
    // [TextArea]
    public List<string> tipsText = new List<string>();
}

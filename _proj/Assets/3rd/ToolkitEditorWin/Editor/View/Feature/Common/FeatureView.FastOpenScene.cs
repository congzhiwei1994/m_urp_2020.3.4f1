using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public partial class FeatureView : View
    {
        public bool openScene = true;
        public void DrawOpenSceneGUI()
        {
            FeatureButton("快速打开场景");
        }
    }

}

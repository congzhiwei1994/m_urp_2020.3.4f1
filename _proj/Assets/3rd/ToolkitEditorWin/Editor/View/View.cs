using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public class View
    {

        FeatureView feature;
        TypeView type;
        public void IntView()
        {
            feature = new FeatureView();
            type = new TypeView();
            type.IntTypeView();
        }

        public void DrawViewGUI()
        {
            feature.DrawFeatureGUI();
            type.DrawTypeGUI();
        }

        public bool Button(string name)
        {
            return GUILayout.Button(name);
        }
    }

}

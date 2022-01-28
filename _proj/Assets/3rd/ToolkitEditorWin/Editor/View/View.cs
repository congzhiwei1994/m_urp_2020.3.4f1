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
            type.DrawTypeGUI();
            feature.DrawFeatureGUI();


        }

        public bool TypeButton(string name)
        {
            return GUILayout.Button(name, GUILayout.Width(80), GUILayout.Height(30));
        }
        public bool FeatureButton(string name)
        {
            return GUILayout.Button(name, GUILayout.Width(80), GUILayout.Height(40));
        }
    }

}

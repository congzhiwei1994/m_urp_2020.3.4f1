using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public partial class FeatureView
    {
        public void DrawFeatureGUI()
        {
            GUIStyle style = new GUIStyle(EditorStyles.helpBox);

            EditorGUILayout.BeginVertical(style);
            {
                DrawOpenSceneGUI();
            }
            EditorGUILayout.EndVertical();
        }
    }

}

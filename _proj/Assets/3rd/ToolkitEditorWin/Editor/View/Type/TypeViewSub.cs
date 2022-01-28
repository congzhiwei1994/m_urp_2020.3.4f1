using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public partial class TypeViewSub
    {
        public void DrawTypeSubGUI()
        {
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            {
                EditorGUILayout.LabelField(" ", GUILayout.Width(80), GUILayout.Height(30));
                DrawCommonGUI();
                DrawTAGUI();
                DrawCharacterGUI();
                DrawSceneGUI();
                DrawVFXGUI();
                DrawVFXScheme();
                DrawResGUI();

            }
            EditorGUILayout.EndHorizontal();

        }
    }

}

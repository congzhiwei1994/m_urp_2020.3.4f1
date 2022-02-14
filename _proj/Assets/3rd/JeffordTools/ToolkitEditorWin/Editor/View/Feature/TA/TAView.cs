using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public partial class TAView
    {
        public string[] taFeatName = new string[] { "计算器", "渐变图生成", "修改Shader属性" };
        public int taFeatID;

        public TAView()
        {
            InitRampMap();
        }
        public void DrawTAGUI()
        {
            EditorGUILayout.BeginHorizontal();
            {

                taFeatID = SelectionGrid(taFeatID, taFeatName);
                GUIStyle style = new GUIStyle();
                GUILayout.BeginScrollView(Vector2.zero, box);
                {

                    switch (taFeatID)
                    {
                        case 0:
                            break;
                        case 1:
                            DrawRampMapGUI();
                            break;
                    }
                }
                GUILayout.EndScrollView();
            }

            EditorGUILayout.EndHorizontal();
        }
    }

}

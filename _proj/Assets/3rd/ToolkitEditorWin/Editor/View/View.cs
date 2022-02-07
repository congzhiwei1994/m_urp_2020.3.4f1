using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Internal;
using System;

namespace TA.Tools
{
    public class View
    {
        public string[] typeName = new string[] { "共用", "角色", "场景", "特效", "TA", "资源检测" };
        private int typeID;
        TAView taView;
        private GUISkin skin;
        public Vector2 size = new Vector2(80, 30);

        public GUIStyle box
        {
            get
            {
                return EditorStyles.helpBox;
            }
        }

        public void IntView()
        {
            skin = (GUISkin)AssetDatabase.LoadAssetAtPath("Assets/3rd/ToolkitEditorWin/Editor/ToolkitEditorWinSkin.guiskin", typeof(GUISkin));
            taView = new TAView();
        }

        public void DrawViewGUI()
        {
            // GUI.skin = skin;
            EditorGUILayout.BeginHorizontal(box, GUILayout.ExpandWidth(true), GUILayout.Height(30));
            {
                EditorGUILayout.LabelField(" ", GUILayout.Width(100), GUILayout.Height(30));
                typeID = GUILayout.SelectionGrid(typeID, typeName, 6, GUILayout.ExpandHeight(true));
            }
            EditorGUILayout.EndHorizontal();
            GUILayout.Space(5);
            EditorGUILayout.BeginVertical(box);
            {
                DrawFeatureGUI(typeID);
            }
            EditorGUILayout.EndVertical();
        }

        public void DrawFeatureGUI(int selectID)
        {
            switch (selectID)
            {
                case 0:
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    taView.DrawTAGUI();
                    break;
                case 5:
                    break;
            }
        }

        public int SelectionGrid(int iD, string[] name)
        {
            var selectID = GUILayout.SelectionGrid(iD, name, 1, GUILayout.Width(80), GUILayout.Height(100));
            return selectID;
        }

        public bool Button(string name, Vector2 vector2)
        {
            return GUILayout.Button(name, GUILayout.Width(vector2.x), GUILayout.Height(vector2.y));
        }

        public Enum EnumPopup(string name, Enum select, Vector2 vector2)
        {
            select = EditorGUILayout.EnumPopup(name, select, GUILayout.Width(vector2.x), GUILayout.Height(vector2.y));
            return select;
        }
    }

}

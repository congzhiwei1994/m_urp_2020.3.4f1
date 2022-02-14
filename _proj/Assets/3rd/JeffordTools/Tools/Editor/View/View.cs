using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.Tools
{
    public class View
    {
        public string[] typeName = new string[] { "共用", "角色", "场景", "特效", "TA", "资源检测" };
        private int typeID;

        public void UpdateView()
        {

            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true), GUILayout.Height(30));
            {
                EditorGUILayout.LabelField(" ", GUILayout.Width(100), GUILayout.Height(30));
                typeID = GUILayout.SelectionGrid(typeID, typeName, 6, GUILayout.ExpandHeight(true));
            }
            EditorGUILayout.EndHorizontal();

            switch (typeID)
            {
                case 0:
                    break;
                case 1:
                    DrawCharacterFeature();
                    break;
                case 2:
                    DrawSceneFeature();
                    break;
                case 3:
                    DrawVFXFeature();
                    break;
                case 4:
                    DrawTAGFeature();
                    break;
                case 5:
                    DrawResChekFeature();
                    break;
            }
        }

        protected virtual void DrawCharacterFeature()
        {

        }
        protected virtual void DrawSceneFeature()
        {

        }
        protected virtual void DrawVFXFeature()
        {

        }
        protected virtual void DrawTAGFeature()
        {

        }
        protected virtual void DrawResChekFeature()
        {

        }

    }

}

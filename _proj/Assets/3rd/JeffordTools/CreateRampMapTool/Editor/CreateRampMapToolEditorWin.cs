using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.TA.CreateRampMapTool
{
    public enum TextureSize
    {
        _64x64,
        _128x128,
        _256x256,
    }
    public class CreateRampMapToolEditorWin : EditorWindow
    {


        TextureSize texSize;
        Gradient gradient;

        [MenuItem("Jefford/渐变图纹理创建工具")]
        public static void Open()
        {
            var window = GetWindow<CreateRampMapToolEditorWin>("渐变图纹理创建工具");
            window.Show();
        }

        private void OnEnable()
        {
            Init();
        }

        public void Init()
        {
            texSize = TextureSize._128x128;
            gradient = new Gradient();
        }

        private void OnGUI()
        {
            UpdateGUI();
        }

        public void UpdateGUI()
        {
            GUILayout.BeginVertical(EditorStyles.helpBox);
            {
                texSize = (TextureSize)EditorGUILayout.EnumPopup("图片大小", texSize);
                GUILayout.Space(5);
                EditorGUILayout.GradientField("图片颜色", gradient);
                GUILayout.Space(5);
                if (GUILayout.Button("保存"))
                {

                }
            }
            GUILayout.EndVertical();
        }
    }

}

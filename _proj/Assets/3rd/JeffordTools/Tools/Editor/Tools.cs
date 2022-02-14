using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.Tools
{
    public class Tools : EditorWindow
    {
        TAView taView;
        CharacterView characterView;
        SceneView sceneView;

        [MenuItem("TA/工具合集 &x")]
        private static void Window()
        {
            var win = GetWindow<Tools>("工具集");
            win.Show();
        }

        private void OnEnable()
        {
            // 初始化界面
            InitView();
        }
        void InitView()
        {
            taView = new TAView();
            characterView = new CharacterView();
            sceneView = new SceneView();
        }
        void OnGUI()
        {
            UpdateGUI();
        }

        void UpdateGUI()
        {
            taView.UpdateView();
            characterView.UpdateView();
            sceneView.UpdateView();
        }

        private void OnDisable()
        {
        }

    }

}

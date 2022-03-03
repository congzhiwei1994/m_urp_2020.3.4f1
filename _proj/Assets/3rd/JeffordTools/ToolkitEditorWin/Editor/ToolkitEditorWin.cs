using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public class ToolkitEditorWin : EditorWindow
    {

        View view;
        TAView taView;

        public string[] typeName = new string[] { "共用", "角色", "场景", "特效", "TA", "资源检测" };

        [MenuItem("TA/工具集")]
        private static void Window()
        {
            var win = GetWindow<ToolkitEditorWin>("工具集");
            win.maxSize = new Vector2(700, 400);
            win.minSize = new Vector2(700, 400);
            win.Show();
        }
        private void Awake()
        {

        }

        private void OnEnable()
        {
            view = new View();
            view.IntView();
        }

        void OnGUI()
        {
            view.DrawViewGUI();
        }


        private void OnDisable()
        {
            view.DisView();
        }

    }

}

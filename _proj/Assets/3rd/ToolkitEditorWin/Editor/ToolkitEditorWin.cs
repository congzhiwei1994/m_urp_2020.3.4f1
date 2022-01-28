using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace TA.Tools
{
    public class ToolkitEditorWin : EditorWindow
    {

        View view;

        [MenuItem("TA/工具集")]
        private static void Window()
        {
            var win = GetWindow<ToolkitEditorWin>("工具集");
            win.maxSize = new Vector2(750, 350);
            win.minSize = new Vector2(750, 350);
            win.Show();
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

        }

    }

}

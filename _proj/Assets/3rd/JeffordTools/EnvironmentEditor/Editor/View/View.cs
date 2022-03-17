using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.EnvironmentEditor
{
    public class View
    {
        private string m_title;
        private bool m_isScrollable;
        private Vector2 m_scrollViewPos = Vector2.zero;

        /// <summary>
        /// 面板
        /// </summary>
        /// <param name="title"></名字>
        /// <param name="isScrollable"></是否可以拖动>
        public View(string title, bool isScrollable = false)
        {
            m_title = title;
            m_isScrollable = isScrollable;
        }

        public void UpdateViewGUI(Event e, Rect rect)
        {
            if (m_isScrollable)
            {
                m_scrollViewPos = EditorGUILayout.BeginScrollView(m_scrollViewPos, GUILayout.Width(rect.width), GUILayout.Height(rect.height));
                OnViewGUI(e);
                EditorGUILayout.EndScrollView();
            }

            else
            {
                OnViewGUI(e);
            }
        }

        public void OnDestroy()
        {
            OnClose();
        }

        protected virtual void OnClose()
        {

        }

        protected virtual void OnViewGUI(Event e)
        {

        }


    }
}

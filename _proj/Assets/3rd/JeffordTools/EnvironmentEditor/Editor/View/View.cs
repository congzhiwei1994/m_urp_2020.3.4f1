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
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector.Editor;
using UnityEditor;

namespace Jefford.PerformanceAdvisor
{
    public class AssetsAdvisorWindow : OdinEditorWindow
    {
        [MenuItem("Jefford/Performance Advisor/Assets Advisor")]
        public static void Init()
        {
            var win = GetWindow<AssetsAdvisorWindow>("Assets Advisor");
            win.Show();
        }
    }
}


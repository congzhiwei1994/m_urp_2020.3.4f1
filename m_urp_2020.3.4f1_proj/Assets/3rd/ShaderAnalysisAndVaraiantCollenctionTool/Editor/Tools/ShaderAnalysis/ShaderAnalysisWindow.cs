/*
    Data:2021-10
    By:uyself
*/
using UnityEngine;
using UnityEditor;
namespace Uy.ShaderAnalysis
{
    public class ShaderAnalysisWindow : EditorWindow
    {
        static ShaderAnalysisWindow _window;
        private AnalysisConsts.Options curModel = AnalysisConsts.Options.prefab_model;

        static AnalysisHelper helper;

        [MenuItem("Tools/Shader分析器")]
        public static void OpenWindow()
        {
            _window = (ShaderAnalysisWindow)GetWindowWithRect(typeof(ShaderAnalysisWindow), new Rect(100, 100, 600, 900), false, "Shader分析器");
            _window.Show();
        }

        private void OnGUI()
        {
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("选择分析模式:", GUILayout.Width(80));
            curModel = (AnalysisConsts.Options)EditorGUILayout.EnumPopup(curModel, GUILayout.Width(200));
            if (helper == null)
            {
                helper = AnalysisHelper.GetHelperIns();
            }
            helper.SetModel(curModel);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("模式说明:", GUILayout.Width(80));
            EditorGUILayout.LabelField(helper.GetModel().GetModelDes(), GUILayout.Width(420));
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("=========================================================", GUILayout.Width(480));

            if (GUILayout.Button(helper.GetModel().GetButtonName(), GUILayout.Width(100)))
            {
                helper.GetModel().StartAnalysis();
            }
            GUILayout.EndHorizontal();

            helper.GetModel().ShowGUI();

            helper.GetModel().AnalysisReprot();

            helper.GetModel().AnalysisSummary();
        }
    }
}
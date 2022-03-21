using UnityEditor;
using UnityEngine;

public class ToolsMain : EditorWindow
{
    private static ToolsMain main;

    [MenuItem("TA/工具箱")]
    public static void ShowMyWindow()
    {
        ToolKitCtrl.Instance.OnBeforeOpen();
        if (main != null) return;
        main = EditorWindow.GetWindow<ToolsMain>("工具箱");
        main.position = new Rect(Vector2.one * 0.5f, new Vector2(Screen.width, Screen.height));
        main.minSize = new Vector2(1280, 720);
        main.Show();
    }
    #region 窗体事件调用
    private void OnGUI()
    {
        ToolKitCtrl.Instance.OnGUI();
    }

    /// <summary>
    /// 监视面板调用
    /// </summary>
    private void OnInspectorUpdate()
    {
        ToolKitCtrl.Instance.OnInspectorUpdate();
    }

    private void OnValidate()
    {
        ToolKitCtrl.Instance.OnValidate();
    }

    private void OnDisable()
    {
        ToolKitCtrl.Instance.OnDisable();
    }

    /// <summary>
    /// 当窗口关闭时调用
    /// </summary>
    private void OnDestroy()
    {
        ToolKitCtrl.Instance.OnDestroy();
        if (main != null)
        {
            main = null;
        }
    }

    /// <summary>
    /// 当场景改变时调用
    /// </summary>
    private void OnProjectChange()
    {
        ToolKitCtrl.Instance.OnProjectChange();
    }
    /// <summary>
    /// 当选择对象属性改变时调用
    /// </summary>
    private void OnHierarchyChange()
    {
        ToolKitCtrl.Instance.OnHierarchyChange();
    }
    /// <summary>
    /// 当窗口获取键盘焦点时调用
    /// </summary>
    private void OnFocus()
    {
        ToolKitCtrl.Instance.OnFocus();
    }
    /// <summary>
    /// 当窗口得到焦点时调用
    /// </summary>
    private void OnGetFocus()
    {
        ToolKitCtrl.Instance.OnGetFocus();
    }
    /// <summary>
    /// 当窗口失去焦点时调用
    /// </summary>
    private void OnLostFocus()
    {
        ToolKitCtrl.Instance.OnLostFocus();
    }
    /// <summary>
    /// 当改变选择不同对象时调用
    /// </summary>
    private void OnSelectionChange()
    {
        ToolKitCtrl.Instance.OnSelectionChange();
    }
    #endregion
}
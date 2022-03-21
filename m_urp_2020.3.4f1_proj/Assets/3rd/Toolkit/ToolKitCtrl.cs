using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System;

public class ToolKitCtrl
{
    private const string toolPath = "/3rd/Toolkit/ToolKits";
    private Vector2Int size = new Vector2Int(1280, 720);
    private int maxShowCount = 5;

    private static ToolKitCtrl ctrl;

    public static ToolKitCtrl Instance
    {
        get
        {
            if (ctrl == null) ctrl = new ToolKitCtrl();
            return ctrl;
        }
    }
    public List<Type> allTool = new List<System.Type>();
    /// <summary>
    /// 所有已打开的工具
    /// </summary>
    private Dictionary<string, BaseToolKit> opened = new Dictionary<string, BaseToolKit>();
    /// <summary>
    /// 所有已打开的工具排序栈
    /// </summary>
    private List<BaseToolKit> openedStack = new List<BaseToolKit>();
    /// <summary>
    /// 最近打开的工具
    /// </summary>
    private List<string> history = new List<string>();

    private GUISkin skin;
    private int selected;

    public void NewTool(BaseToolKit tool)
    {
        if (!opened.ContainsKey(tool.Content().text))
        {
            opened.Add(tool.Content().text, tool);
            openedStack.Add(tool);
            tool.OnAwake();
        }
    }

    public bool OpenTool(string name)
    {
        return opened.ContainsKey(name);
    }

    public void DelateTool(string name)
    {
        BaseToolKit tool;
        if (opened.TryGetValue(name, out tool))
        {
            opened.Remove(name);
            openedStack.Remove(tool);
            tool.OnDestroy();
        }
    }

    /// <summary>
    /// 打开工具箱之前调用
    /// </summary>
    public void OnBeforeOpen()
    {
        //创建起始页
        NewTool(new ToolSercher());
        //加载所有工具Type
        string fullPath = Application.dataPath + toolPath;
        //获取指定路径下面的所有工具类
        if (Directory.Exists(fullPath))
        {
            DirectoryInfo direction = new DirectoryInfo(fullPath);
            FileInfo[] files = direction.GetFiles("*", SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; i++)
            {
                if (files[i].Name.EndsWith(".cs"))
                {
                    string className = files[i].Name.Substring(0, files[i].Name.IndexOf('.'));
                    var tool = Type.GetType(className);
                    if (tool != null)
                    {
                        if (!allTool.Contains(tool) && tool.BaseType.Name == "BaseToolKit")
                            allTool.Add(tool);
                    }
                    else
                        Debug.LogError(fullPath + "文件夹下的工具类：" + className + " 文件名与类名不一致！");
                }
            }
        }
    }

    public void OnGUI()
    {
        if (openedStack.Count > 0 && selected < openedStack.Count)
        {
            EditorGUILayout.BeginHorizontal(GUILayout.Width(size.x), GUILayout.Height(30));
            {
                int width = size.x;
                if (openedStack.Count <= maxShowCount)
                    width = openedStack.Count * (size.x / maxShowCount);
                selected = GUILayout.Toolbar(selected, openedStack.Select(s => s.Content()).ToArray(), GUILayout.Width(width), GUILayout.ExpandHeight(true));
            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginVertical("box", GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            {
                openedStack[selected].OnGUI();
            }
            EditorGUILayout.EndVertical();
        }
    }

    public void OnDestroy()
    {
        if (openedStack.Count > 0)
        {
            foreach (var tool in openedStack)
                tool.OnDestroy();
            openedStack.Clear();
            opened.Clear();
        }
    }

    public void OnInspectorUpdate()
    {

    }

    public void OnValidate()
    {

    }

    public void OnDisable()
    {

    }

    public void OnProjectChange()
    {

    }

    public void OnHierarchyChange()
    {

    }

    public void OnFocus()
    {

    }

    public void OnGetFocus()
    {

    }

    public void OnLostFocus()
    {

    }

    public void OnSelectionChange()
    {

    }
}
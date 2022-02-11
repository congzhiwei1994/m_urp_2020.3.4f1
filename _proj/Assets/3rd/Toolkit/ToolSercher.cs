using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ToolSercher : BaseToolKit
{
    private GUIStyle TextFieldRoundEdge;
    private GUIStyle TextFieldRoundEdgeCancelButton;
    private GUIStyle TextFieldRoundEdgeCancelButtonEmpty;
    private GUIStyle TransparentTextField;

    private string m_InputSearchText;

    private Vector2 scrollVector2 = Vector2.zero;

    public override GUIContent Content()
    {
        return new GUIContent("工具搜索");
    }

    public override GUIStyle Style()
    {
        return new GUIStyle("ToolbarSeachCancelButtonEmpty");
    }

    public override void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        {
            DrawInputTextField();
            scrollVector2 = EditorGUILayout.BeginScrollView(scrollVector2);
            {
                DrawAllTool();
            }
            EditorGUILayout.EndScrollView();
        }
        EditorGUILayout.EndVertical();

    }

    /// <summary>
    /// 绘制输入框，放在OnGUI函数里
    /// </summary>
    private void DrawInputTextField()
    {
        if (TextFieldRoundEdge == null)
        {
            TextFieldRoundEdge = new GUIStyle("SearchTextField");
            TextFieldRoundEdgeCancelButton = new GUIStyle("SearchCancelButton");
            TextFieldRoundEdgeCancelButtonEmpty = new GUIStyle("SearchCancelButtonEmpty");
            TransparentTextField = new GUIStyle(EditorStyles.whiteLabel);
            TransparentTextField.normal.textColor = EditorStyles.textField.normal.textColor;
        }

        //获取当前输入框的Rect(位置大小)
        Rect position = EditorGUILayout.GetControlRect();
        //设置圆角style的GUIStyle
        GUIStyle textFieldRoundEdge = TextFieldRoundEdge;
        //设置输入框的GUIStyle为透明，所以看到的“输入框”是TextFieldRoundEdge的风格
        GUIStyle transparentTextField = TransparentTextField;
        //选择取消按钮(x)的GUIStyle
        GUIStyle gUIStyle = (m_InputSearchText != "") ? TextFieldRoundEdgeCancelButton : TextFieldRoundEdgeCancelButtonEmpty;

        //输入框的水平位置向左移动取消按钮宽度的距离
        position.width -= gUIStyle.fixedWidth;
        //如果面板重绘
        if (Event.current.type == EventType.Repaint)
        {
            //根据是否是专业版来选取颜色
            GUI.contentColor = (EditorGUIUtility.isProSkin ? Color.black : new Color(0f, 0f, 0f, 0.5f));
            //当没有输入的时候提示“请输入”
            if (string.IsNullOrEmpty(m_InputSearchText))
            {
                textFieldRoundEdge.Draw(position, new GUIContent("请输入工具名"), 0);
            }
            else
            {
                textFieldRoundEdge.Draw(position, new GUIContent(""), 0);
            }
            //因为是“全局变量”，用完要重置回来
            GUI.contentColor = Color.white;
        }
        Rect rect = position;
        //为了空出左边那个放大镜的位置
        float num = textFieldRoundEdge.CalcSize(new GUIContent("")).x - 2f;
        rect.width -= num;
        rect.x += num;
        rect.y += 1f;//为了和后面的style对齐

        m_InputSearchText = EditorGUI.TextField(rect, m_InputSearchText, transparentTextField);
        //Debug.LogError(m_InputSearchText);
        //绘制取消按钮，位置要在输入框右边
        position.x += position.width;
        position.width = gUIStyle.fixedWidth;
        position.height = gUIStyle.fixedHeight;
        if (GUI.Button(position, GUIContent.none, gUIStyle) && m_InputSearchText != "")
        {
            m_InputSearchText = "";
            //用户是否做了输入
            GUI.changed = true;
            //把焦点移开输入框
            GUIUtility.keyboardControl = 0;
        }
    }

    private void DrawAllTool()
    {
        if (ToolKitCtrl.Instance.allTool.Count > 0)
        {
            foreach (var tool in ToolKitCtrl.Instance.allTool)
            {
                if (!string.IsNullOrEmpty(m_InputSearchText))
                {
                    if (tool.Name.ToLower().Contains(m_InputSearchText.ToLower()))
                        DrawToolView(tool);
                }
                else
                    DrawToolView(tool);
            }
        }
    }

    private void DrawToolView(Type tool)
    {
        GUILayout.BeginHorizontal("FrameBox");
        GUILayout.Space(40);
        EditorGUILayout.SelectableLabel(tool.Name);
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("打开工具"))
        {
            if (!ToolKitCtrl.Instance.OpenTool(tool.Name))
                ToolKitCtrl.Instance.NewTool(Activator.CreateInstance(tool) as BaseToolKit);
        }
        GUILayout.EndHorizontal();
        GUILayout.Space(10);
    }
}

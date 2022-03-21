using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CacaulatorWin : EditorWindow
{

    [MenuItem("Jefford/键盘")]
    private static void Window()
    {
        var win = GetWindow<CacaulatorWin>("键盘");
        win.maxSize = new Vector2(620, 200);
        win.minSize = new Vector2(620, 200);
        win.Show();
    }

    private void OnGUI()
    {
        int width = 40;
        int height = 30;
        GUIStyle style = new GUIStyle();


        EditorGUILayout.BeginVertical(style);
        {
            DrawFGUI(width, height);
            DrawNumGUI(width, height);
            DrawTabGUI(width, height);
            DrawCapsGUI(width, height);
            DrawShiftGUI(width, height);
            DrawCtrlGUI(width, height);
        }
        EditorGUILayout.EndVertical();

    }

    private void DrawFGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
        {
            GUILayout.Button("Esc", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F1", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F2", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F3", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F4", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F5", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F6", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F7", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F8", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F9", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F10", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F11", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F12", GUILayout.Width(width), GUILayout.Height(height));
        }
        EditorGUILayout.EndHorizontal();
    }
    private void DrawNumGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
        {
            GUILayout.Button("~", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("1", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("2", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("3", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("4", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("5", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("6", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("7", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("8", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("9", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("0", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("-", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("+", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Back", GUILayout.ExpandWidth(true), GUILayout.Height(height));
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawTabGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Button("Tab", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Q", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("W", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("E", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("R", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("T", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Y", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("U", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("I", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("O", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("P", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("{", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("}", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Enable", GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawCapsGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Button("Caps Lock", GUILayout.ExpandWidth(true), GUILayout.Height(height));
            GUILayout.Button("A", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("S", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("D", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("F", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("G", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("H", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("J", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("K", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("L", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button(":", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("'", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("|", GUILayout.Width(width), GUILayout.Height(height));
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawShiftGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Button("Shift", GUILayout.ExpandWidth(true), GUILayout.Height(height));
            GUILayout.Button("Z", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("X", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("C", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("V", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("B", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("N", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("M", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("<", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button(">", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("?", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("shift", GUILayout.Width(width), GUILayout.Height(height));
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DrawCtrlGUI(int width, int height)
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Button("Ctrl", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Win", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Space", GUILayout.ExpandWidth(true), GUILayout.Height(height));
            GUILayout.Button("Alt", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("FN", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Win", GUILayout.Width(width), GUILayout.Height(height));
            GUILayout.Button("Ctrl", GUILayout.Width(width), GUILayout.Height(height));
        }
        EditorGUILayout.EndHorizontal();
    }
}

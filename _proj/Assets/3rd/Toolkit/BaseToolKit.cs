using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class BaseToolKit
{
    public abstract GUIContent Content();

    public virtual GUIStyle Style() { return new GUIStyle("ToolbarSeachCancelButton"); }

    public virtual void OnAwake() { }

    public abstract void OnGUI();

    public virtual void OnDestroy() { }
}

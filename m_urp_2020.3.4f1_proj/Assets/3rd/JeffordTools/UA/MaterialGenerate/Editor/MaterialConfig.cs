using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.MaterialGenerate
{
    [System.Serializable]
    public abstract class MaterialConfig : ScriptableObject
    {
        protected abstract void OnInitCom(MaterialGenerate context);
        protected abstract string OnGetName(MaterialGenerate context);
        protected abstract Shader OnGetShader(MaterialGenerate context);
        protected virtual void OnInitMaterial(MaterialGenerate context, Material material)
        {

        }

        public string GetDisPlayName()
        {
            return this.OnGetName(null);
        }
    }
}

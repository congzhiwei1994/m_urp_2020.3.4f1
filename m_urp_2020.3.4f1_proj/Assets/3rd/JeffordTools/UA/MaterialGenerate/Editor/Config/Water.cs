using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.MaterialGenerate
{
    public class Water : MaterialConfig
    {
        protected override void OnInitCom(MaterialGenerate context)
        {
            throw new System.NotImplementedException();
        }
        protected override string OnGetName(MaterialGenerate context)
        {
            return "水";
        }
        protected override Shader OnGetShader(MaterialGenerate context)
        {
            throw new System.NotImplementedException();
        }


    }
}

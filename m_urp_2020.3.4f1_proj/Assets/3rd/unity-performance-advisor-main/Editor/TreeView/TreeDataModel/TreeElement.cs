using System;
using System.Collections.Generic;
using UnityEngine;

namespace EditorKit
{
	[Serializable]
	public class TreeElement
	{
		int m_ID;
		string m_Name;
		int m_Depth;
		TreeElement m_Parent;
		List<TreeElement> m_Children;

		public int depth
		{
			get { return m_Depth; }
			set { m_Depth = value; }
		}

		public TreeElement parent
		{
			get { return m_Parent; }
			set { m_Parent = value; }
		}

		public List<TreeElement> children
		{
			get { return m_Children; }
			set { m_Children = value; }
		}

		public bool hasChildren
		{
			get { return children != null && children.Count > 0; }
		}

		public string name
		{
			get { return m_Name; } set { m_Name = value; }
		}

		public int id
		{
			get { return m_ID; } set { m_ID = value; }
		}

		public TreeElement ()
		{
		}

		protected TreeElement (string name, int depth, int id)
		{
			m_Name = name;
			m_ID = id;
			m_Depth = depth;
		}

		public static TreeElement Init()
		{
			return new TreeElement("", -1, 0);
		}
	}

}


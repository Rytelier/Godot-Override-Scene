@tool
extends EditorPlugin

var selection : EditorSelection
var filesystem = get_editor_interface().get_resource_filesystem()

var saveSceneId = 101

func _enter_tree():
	selection = get_editor_interface().get_selection()
	
	get_editor_interface().get_tree()
	
	FindSceneTreePopup()

func _exit_tree():

	pass

func FindSceneTreePopup():
	var sceneTreeEditor : Array[Node]
	var popup
	FindByClass(get_editor_interface().get_window(), "SceneTreeDock", sceneTreeEditor)
	print(sceneTreeEditor)
	
	if sceneTreeEditor.size() > 0:
		for child in sceneTreeEditor[0].get_children():
			# this is what we want
			var pop:PopupMenu = child as PopupMenu

			if not pop: continue

			popup = pop
			popup.connect("about_to_popup", AddItemToPopup.bind(pop))
			popup.connect("id_pressed", SaveScene.bind())

func AddItemToPopup(popup : Popup):
	var selected : Array[Node] = selection.get_selected_nodes()
	
	if selected.size() > 0:
		var path = selected[0].scene_file_path
		if path != null and path != "":
			popup.add_separator("Override scene (beta)")
			popup.add_icon_item(get_editor_interface().get_base_control().get_theme_icon('PackedScene', 'EditorIcons'), "Override scene", saveSceneId)

func FindByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className) :
		result.push_back(node)
	for child in node.get_children():
		FindByClass(child, className, result)

func SaveScene(id : int):
	if id == saveSceneId:
		var selected : Array[Node] = selection.get_selected_nodes()
		
		if selected.size() > 0:
			var path = selected[0].scene_file_path
			if path != null and path != "":
				var scene : PackedScene = PackedScene.new()
				scene.pack(selected[0])
				ResourceSaver.save(scene, path)
				print("Saved ", path)
				filesystem.reimport_files([path])

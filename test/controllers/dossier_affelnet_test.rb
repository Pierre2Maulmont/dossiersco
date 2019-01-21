require 'test_helper'

class DossierAffelnetControllerTest < ActionDispatch::IntegrationTest

  def test_upload_un_fichier_puis_affiche_un_compte_rendu_du_contenu
    admin = Fabricate(:admin)
    post agent_url, params: {identifiant: admin.identifiant, mot_de_passe: admin.password}
    follow_redirect!

    import_affelnet_xls = fixture_file_upload('files/test_import_affelnet_4_lignes.xlsm','application/vnd.ms-excel')

    post dossier_affelnet_url, params: {fichier: import_affelnet_xls}

    assert_response :success
    assert_equal "test_import_affelnet_4_lignes.xlsm", assigns(:nom_fichier)
    assert_equal 4, assigns(:nombre_de_lignes)
  end

end
defmodule KeyBasedStorageWeb.Test.Controller.ApiControllerTest do
  use KeyBasedStorageWeb.ConnCase

  alias KeyBasedStorage.Repo
  alias KeyBasedStorage.Schemas.KeyBase

  import Ecto.Query

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "text/plain")
    %{conn: conn}
  end

  describe "index/2" do
    test "With valid set command, and value as integers sets value to value_integer field", %{conn: conn} do
      command = "set new_key 10"

      response = 
        conn
        |> put_req_header("x-client-name", "Ada")
        |> post("/api", command) 

      assert response.resp_body == "NIL 10"

      query = from(kb in KeyBase, where: kb.key == "new_key")
      key_base = Repo.one(query)

      assert key_base.value_integer == 10
      assert is_nil(key_base.value_string)
      assert is_nil(key_base.value_boolean)
    end

    test "With valid set command and value as boolean sets value to value_boolean field", %{conn: conn} do
      command = "set new_key2 true"

      response = 
        conn
        |> put_req_header("x-client-name", "Ada")
        |> post("/api", command) 

      assert response.resp_body == "NIL true"

      query = from(kb in KeyBase, where: kb.key == "new_key2")
      key_base = Repo.one(query)

      assert is_nil(key_base.value_integer)
      assert is_nil(key_base.value_string)
      assert key_base.value_boolean
    end

    test "With valid set command and value as string sets value to value_string field", %{conn: conn} do
      command = "set new_key3 \"true\""

      response = 
        conn
        |> put_req_header("x-client-name", "Ada")
        |> post("/api", command) 

      assert response.resp_body == "NIL \"true\""

      query = from(kb in KeyBase, where: kb.key == "new_key3")
      key_base = Repo.one(query)

      assert is_nil(key_base.value_integer)
      assert String.valid?(key_base.value_string)
      assert is_nil(key_base.value_boolean)
    end

    test "When a user start a transaction, its changes are only visible to it", %{conn: conn} do
      conn_user_1 = put_req_header(conn, "x-client-name", "Ada")
      conn_user_2 = put_req_header(conn, "x-client-name", "Lovelace")

      #Starts transaction for user 1
      response = post(conn_user_1, "/api", "BEGIN")
      assert response.resp_body == "OK"

      #Sets value 10 to key_01
      response = post(conn_user_1, "/api", "set key_1 10")
      assert response.resp_body == "NIL 10"

      #Gets value to key_1 from user 2
      response = post(conn_user_2, "/api", "get key_1")
      assert response.resp_body == "Key not found key_1"

      #Value should be visible to user 1
      response = post(conn_user_1, "/api", "get key_1")
      assert response.resp_body == "10" 
    end

    test "After commit a transaction, changes should be visible to all user", %{conn: conn} do
      conn_user_1 = put_req_header(conn, "x-client-name", "Ada")
      conn_user_2 = put_req_header(conn, "x-client-name", "Lovelace")

      #Starts transaction for user 1
      response = post(conn_user_1, "/api", "BEGIN")
      assert response.resp_body == "OK"

      #Sets value 10 to key_01
      response = post(conn_user_1, "/api", "set key_2 10")
      assert response.resp_body == "NIL 10"

      #Gets value to key_1 from user 2
      response = post(conn_user_2, "/api", "get key_2")
      assert response.resp_body == "Key not found key_2"

      #Value should be visible to user 1
      response = post(conn_user_1, "/api", "get key_2")
      assert response.resp_body == "10" 

      #Commits transaction
      response = post(conn_user_1, "/api", "COMMIT")
      assert response.resp_body == "OK"

      #Gets value to key_1 from user 2
      response = post(conn_user_2, "/api", "get key_2")
      assert response.resp_body == "10" 
    end

    test "After rollback a transaction, changes should not br applyed to database", %{conn: conn} do
      conn_user_1 = put_req_header(conn, "x-client-name", "Ada")
      conn_user_2 = put_req_header(conn, "x-client-name", "Lovelace")

      #Starts transaction for user 1
      response = post(conn_user_1, "/api", "BEGIN")
      assert response.resp_body == "OK"

      #Sets value 10 to key_01
      response = post(conn_user_1, "/api", "set key_3 10")
      assert response.resp_body == "NIL 10"

      #Gets value to key_1 from user 2
      response = post(conn_user_2, "/api", "get key_3")
      assert response.resp_body == "Key not found key_3"

      #Value should be visible to user 1
      response = post(conn_user_1, "/api", "get key_3")
      assert response.resp_body == "10" 

      #Rollback transaction
      response = post(conn_user_1, "/api", "ROLLBACK")
      assert response.resp_body == "OK"

      #Gets value to key_1 from user 2
      response = post(conn_user_2, "/api", "get key_3")
      assert response.resp_body == "Key not found key_3"

      #Gets value to key_1 from user 1 
      response = post(conn_user_1, "/api", "get key_3")
      assert response.resp_body == "Key not found key_3"
    end
  end
end

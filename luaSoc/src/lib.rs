use mlua::{Lua, Result, Table, lua_module};
use std::os::unix::net::UnixStream;
use std::io::{Write, Read};

#[lua_module]
fn luaSoc(lua: &Lua) -> Result<Table> {
    let exports = lua.create_table()?;

    let send_data = lua.create_function(|_, (path, data): (String, String)| {
        let mut stream = UnixStream::connect(&path).map_err(|e| mlua::Error::external(format!("Failed to connect to socket: {}", e)))?;

        stream.write_all(data.as_bytes()).map_err(|e| mlua::Error::external(format!("Failed to write: {}", e)))?;

        stream.flush().map_err(|e| mlua::Error::external(format!("Failed to flush: {}", e)))?;

        let mut res = Vec::new();
        stream.read_to_end(&mut res).map_err(|e| mlua::Error::external(format!("Failed to read response: {}", e)))?;

        let res_s = String::from_utf8_lossy(&res).to_string();
        Ok(res_s) 
    })?;

    exports.set("sendData", send_data)?;
    Ok(exports)
}

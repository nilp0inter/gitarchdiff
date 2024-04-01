use std::io;

extern crate git2;

use git2::Repository;

fn main() -> io::Result<()> {
    let url = "https://github.com/alexcrichton/git2-rs";
    let repo = match Repository::clone(url, "herewego") {
        Ok(repo) => repo,
        Err(e) => panic!("failed to clone: {}", e),
    };

    println!("Cloned repo: {}", repo.path().display());

    Ok(())
}

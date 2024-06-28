# Gitly

Gitly is an Elixir library for easily downloading and extracting Git repositories from various hosting services.

## Features

- Download repositories from popular Git hosts
- Extract downloaded archives
- Flexible options for caching, retrying, and formatting
- Support for various archive formats (zip, tar, tar.gz, tgz) if supported by the provider
- Support for various hosts (GitHub, GitLab, BitBucket)

## Installation

Add `gitly` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gitly, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get` to install the dependency.

## Usage

### Basic Usage

To download and extract a repository:

```elixir
import Gitly, only: [gitly: 1, gitly: 2]
{:ok, path} = gitly("username/repo")
```

This will download the repository and return the path to the extracted contents.

The following inputs are supported:

- `owner/repo`
- `https://host.com/owner/repo`
- `https://host.com/owner/repo.git`
- `host.com/owner/repo`
- `host:owner/repo`

### Download Only

If you only want to download the repository without extracting:

```elixir
import Gitly, only: [download: 1, download: 2]
{:ok, archive_path} = download("username/repo")
```

### Extract an Existing Archive

To extract an already downloaded archive:

```elixir
import Gitly, only: [extract: 1, extract: 2]
{:ok, extracted_path} = extract("/path/to/archive.zip")
```

Or to specify a destination:

```elixir
import Gitly, only: [extract: 1, extract: 2]
{:ok, extracted_path} = extract("/path/to/archive.zip", "/path/to/destination")
```

## Options

Gitly supports various options to customize its behavior:

- `:force` - Force download even if the archive already exists
- `:cache` - Use local cache for downloads
- `:overwrite` - Overwrite existing files when extracting
- `:retry` - Retry options for failed downloads
- `:retry_delay` - Custom function to determine delay between retries
- `:retry_log_level` - Set log level for retry attempts
- `:max_retries` - Maximum number of retry attempts
- `:ref` - Specify a particular Git reference to download
- `:root` - Set the root path for storing archives
- `:format` - Specify the archive format (:zip, :tar, :tar_gz, or :tgz)

Example with options:

```elixir
import Gitly, only: [gitly: 1, gitly: 2]
gitly("username/repo", force: true, format: :zip, ref: "main")
```

## Documentation

For more detailed documentation, run `mix docs` and open `doc/index.html` in your browser.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).
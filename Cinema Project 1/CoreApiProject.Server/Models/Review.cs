﻿using System;
using System.Collections.Generic;

namespace CoreApiProject.Server.Models;

public partial class Review
{
    public int Id { get; set; }

    public int? UserId { get; set; }

    public int? MovieId { get; set; }

    public int? Rating { get; set; }

    public string? Title { get; set; }

    public string? ReviewText { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Movie? Movie { get; set; }

    public virtual User? User { get; set; }
}
